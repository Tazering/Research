from PyPDF2 import PdfReader

number = 16
reader = PdfReader("C:/Users/tyler/dev/Research/fox_multimessenger-astronomy/" + str(number) + ".pdf")

keywords = ["learning", "neural", "machine", "multi", "deep", "convolutional", "rnn", "recurrent", "lstm", "language", "perceptron", "MLP", "messenger", "message", "em", "electromagnetic", "waves", "cosmic", "gravitational", "rays", "neutrinos", "wavelength", "photons", "Supernova", "supernova", "curve", "quasar", "git", "redshift", "pulsar", "radio"]
keywords_dict = {}

for key in keywords:
    keywords_dict[key] = 0

for i in range(len(reader.pages)):
    page = reader.pages[i]
    text = page.extract_text()

    str_arr = text.split(" ")

    for str_val in str_arr:
        if str_val in keywords:
            keywords_dict[str_val] += 1

print(keywords_dict)
